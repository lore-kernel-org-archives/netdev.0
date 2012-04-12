From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v18 15/15] Documentation: prctl/seccomp_filter
Date: Thu, 12 Apr 2012 15:11:50 -0700
Message-ID: <CAGXu5jLLoOqSS_zYehi1TbDXDPqitnAN1S401zgReRgEfUaTYw@mail.gmail.com>
References: <1334267284-19166-1-git-send-email-wad@chromium.org>
	<1334267284-19166-15-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, linux-man@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, coreyb@linux.vnet.ibm.com, jmorris@namei.org
To: Will Drewry <wad@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:36598 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756853Ab2DLWLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 18:11:53 -0400
Received: by bkcik5 with SMTP id ik5so1883783bkc.19
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2012 15:11:52 -0700 (PDT)
In-Reply-To: <1334267284-19166-15-git-send-email-wad@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 12, 2012 at 2:48 PM, Will Drewry <wad@chromium.org> wrote:
> Documents how system call filtering using Berkeley Packet
> Filter programs works and how it may be used.
> Includes an example for x86 and a semi-generic
> example using a macro-based code generator.
>
> Acked-by: Eric Paris <eparis@redhat.com>
> Signed-off-by: Will Drewry <wad@chromium.org>

Acked-by: Kees Cook <keescook@chromium.org>

-- 
Kees Cook
ChromeOS Security
