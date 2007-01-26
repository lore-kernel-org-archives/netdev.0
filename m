From: Jiri Kosina <jikos@jikos.cz>
Subject: Re: r8169 problems on x86_64 (transmit timeout & crash)
Date: Fri, 26 Jan 2007 14:35:31 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0701261429200.1889@twin.jikos.cz>
References: <a37929f0701260500x68cf6bb0i8a5ef603794a861f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: mirek kratochvil <exa.exa@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965641AbXAZNgl@vger.kernel.org>
In-Reply-To: <a37929f0701260500x68cf6bb0i8a5ef603794a861f@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 26 Jan 2007, mirek kratochvil wrote:

> > In case you have BIOS 04.., try to upgrade to 06.. version. Also, does 
> > it help when you boot with acpi=off kernel commandline parameter? (do 
> > you compile kernel with both acpi and apic support?).
> Upgraded to bios 0802, but still the same problem. I think it's 
> definitely something about the r8169 driver. acpi=off doesn't help. 
> turning on/off apic also doesn't matter.

Added some relevant CCs; the thread started in lkml at 
http://lkml.org/lkml/2007/1/25/268

> one thing more - have confirmed that the bug is reproducible on *any* 
> laptop with 8168, not only Asus. I guess the disk-usage-crash was some 
> other bug.

Confusing ... the other day you stated that r1000 has the exactly same 
problem?

Thanks,

-- 
Jiri Kosina
SUSE Labs
