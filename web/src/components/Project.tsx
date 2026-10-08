import type { ProjectData } from '@/components/types';
import { cn } from '@/lib/utils';

type ProjectProps = {
  project: ProjectData;
  isOpen: boolean;
  onChangeState: (id: string) => void;
  onSwitchAccordion: (id: string) => void;
};

const STATE_STYLE: Record<ProjectData['state'], { label: string; className: string }> = {
  TODO: { label: '未着手', className: 'bg-[#F6F6F2] text-[#7B858C]' },
  DOING: { label: '進行中', className: 'bg-[#FBF2DC] text-[#C98A04]' },
  DONE: { label: '完了', className: 'bg-[#E8EEFD] text-[#2B5CE6]' },
};

export default function Project({
  project: { id, title, state, difficulty },
  isOpen,
  onChangeState,
  onSwitchAccordion,
}: ProjectProps) {
  const stateStyle = STATE_STYLE[state];

  return (
    <div className="overflow-hidden rounded-[10px] border border-[#E2E2DA] bg-white">
      <div className="flex items-stretch">
        <button
          type="button"
          className={cn(
            'w-19 shrink-0 cursor-pointer border-r border-[#E2E2DA] text-[12px] font-bold',
            stateStyle.className,
          )}
          onClick={() => onChangeState(id)}
          title="クリックでステータスを切り替え"
        >
          {stateStyle.label}
        </button>
        <button
          type="button"
          className="flex flex-1 cursor-pointer items-center gap-2.5 px-3.5 py-3 text-left text-sm text-[#232E36]"
          onClick={() => onSwitchAccordion(id)}
          aria-expanded={isOpen}
        >
          <span
            className={cn(state === 'DONE' && 'text-[#7B858C] line-through decoration-[#2B5CE6]')}
          >
            {title}
          </span>
          <span className="ml-auto flex flex-wrap gap-1.5">
            {difficulty > 0 && (
              <span className="rounded-[5px] border border-[#FBF2DC] bg-[#FBF2DC] px-1.75 py-px font-mono text-[11px] tracking-[1px] text-[#C98A04]">
                {'★'.repeat(difficulty)}
                {'☆'.repeat(3 - difficulty)}
              </span>
            )}
          </span>
          <span
            className={cn(
              'text-[11px] text-[#7B858C] transition-transform duration-150',
              isOpen && 'rotate-180',
            )}
            aria-hidden={true}
          >
            ▾
          </span>
        </button>
      </div>
      {isOpen && (
        <div className="border-t border-[#E2E2DA] bg-[#FCFCFA] px-4 pt-4 pb-4.5">
          {/* タブ・学習ガイド・記録を別コンポーネントにしてここに置く */}
        </div>
      )}
    </div>
  );
}
