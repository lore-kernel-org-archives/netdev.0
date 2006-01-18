From: Andrew Morton <akpm@osdl.org>
Subject: Re: [git patches] e1000 fixes
Date: Wed, 18 Jan 2006 14:11:18 -0800
Message-ID: <20060118141118.78767e3d.akpm@osdl.org>
References: <20060118212449.GA13260@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932551AbWARWLi@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20060118212449.GA13260@havoc.gtf.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> wrote:
>
> Let's see how this goes...  if there are further problems, I'll just
>  revert the entire thing, and push these changes (and the previous set)
>  into upstream-2.6.17 branch.
> 
>  I don't mind them updating the defconfig files, even though most people
>  are too slack to worry about it, since its pretty clear the default
>  choice.
> 
> 
>  Please pull from 'upstream-fixes' branch of
>  master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git

These patches fix e1000 for me, thanks.
