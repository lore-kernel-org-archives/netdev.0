From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [2.6 patch] drivers/net/ixgb/: possible cleanups
Date: Sat, 07 May 2005 14:24:04 +0200
Message-ID: <1115468645.6388.37.camel@laptopd505.fenrus.org>
References: <20050506211834.GM3590@stusta.de>
	 <5fc59ff3050506153523cd12dd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, ayyappan.veeraiyan@intel.com,
	ganesh.venkatesan@intel.com, john.ronciak@intel.com,
	jgarzik@pobox.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S263080AbVEGMYh@vger.kernel.org>
To: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
In-Reply-To: <5fc59ff3050506153523cd12dd@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2005-05-06 at 15:35 -0700, Ganesh Venkatesan wrote:
> Adrian:
> 
> Some of your suggestions are already part of the driver we are
> currently testing. This was based partly on your Feb '05 patch. We
> will not be able to apply your patch as is since some of the changes
> are in part of code that is shared with other drivers that are not
> GPLd.

this sounds really bad.

Can you talk to the intel people in the ACPI group, they had a similar
issue before but were able to resolve it by a proper dual license
comment. It would be much preferable if people CAN do changes to the
entire driver... what's the point of having it open source otherwise ;)
