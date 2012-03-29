From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH v17 00/15] seccomp_filter: BPF-based syscall filtering
Date: Fri, 30 Mar 2012 10:11:32 +1100 (EST)
Message-ID: <alpine.LRH.2.02.1203301010310.11201@tundra.namei.org>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org,
        linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
        kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
        x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
        mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
        rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
        luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
        djm@mindrot.org, scarybeasts@gmail.com, indan@nul.nu,
        pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
        eric.dumazet@gmail.com, markus@chromium.org, coreyb@linux.vnet.ibm.com,
        keescook@chromium.org
To: Will Drewry <wad@chromium.org>
Return-path: <kernel-hardening-return-1189-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1333051320-30872-1-git-send-email-wad@chromium.org>
List-Id: netdev.vger.kernel.org

On Thu, 29 Mar 2012, Will Drewry wrote:

> Please see prior revisions for a detailed discussion of this patch
> series.
> 
> This series is a rebase on to:
>   b5174fa3a7f4f8f150bfa3b917c92608953dfa0f
> with very minor changes due to rebasing and tweaks noticed by a few
> initial users.  (I will rebase again for v3.4-rc1 when that time comes.)

I've offered to take this via my tree -- if anyone else wants to merge it 
via theirs instead, holler.

-- 
James Morris
<jmorris@namei.org>
