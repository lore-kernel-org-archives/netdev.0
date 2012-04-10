From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH v17 08/15] seccomp: add system call filtering using BPF
Date: Tue, 10 Apr 2012 19:48:56 +1000 (EST)
Message-ID: <alpine.LRH.2.02.1204101948330.28663@tundra.namei.org>
References: <1333051320-30872-1-git-send-email-wad@chromium.org> <1333051320-30872-9-git-send-email-wad@chromium.org> <20120406132330.457a05cf.akpm@linux-foundation.org> <67e30a0c8655fc53a92e8138bba9de66.squirrel@webmail.greenhost.nl>
 <CABqD9hYE0S4EL6yH-57SfNs+D8GFKJgWVN21VzXpQmRuh2ow=w@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Indan Zupancic <indan@nul.nu>, Andrew Morton <akpm@linux-foundation.org>,
        linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org,
        linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
        kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
        x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
        mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
        rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
        luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
        djm@mindrot.org, scarybeasts@gmail.com, pmoore@redhat.com,
        corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
        coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: Will Drewry <wad@chromium.org>
Return-path: <kernel-hardening-return-1231-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CABqD9hYE0S4EL6yH-57SfNs+D8GFKJgWVN21VzXpQmRuh2ow=w@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Mon, 9 Apr 2012, Will Drewry wrote:

> > seccomp_chk_filter() mirrors sk_chk_filter(). So it refers to
> > "chk", not "check".
> 
> I can change it to be written out or leave it matching the networking
> code.  Any preferences?

check :-)


-- 
James Morris
<jmorris@namei.org>
