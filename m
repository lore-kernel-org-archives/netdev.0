From: Roland McGrath <mcgrathr@google.com>
Subject: Re: [PATCH v10 03/11] asm/syscall.h: add syscall_get_arch
Date: Tue, 21 Feb 2012 10:46:53 -0800
Message-ID: <CAB=4xhp6y7Pq7mTF228TdyA-_z2j5z1yEnFrNQrFr7M9BZQ1Fg@mail.gmail.com>
References: <1329845435-2313-1-git-send-email-wad@chromium.org> <1329845435-2313-3-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	tglx@linutronix.de, luto@mit.edu, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, akpm@linux-foundation.org,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	keescook@chromium.org
To: Will Drewry <wad@chromium.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1329845435-2313-3-git-send-email-wad@chromium.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +void syscall_get_arch(struct task_struct *task, struct pt_regs *regs);

Bad return type.
