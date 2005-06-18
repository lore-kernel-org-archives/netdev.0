From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [git patches] 2.6.x net driver updates
Date: Sat, 18 Jun 2005 14:36:38 -0400
Message-ID: <42B469B6.2060502@pobox.com>
References: <42B456E2.8000500@pobox.com> <Pine.LNX.4.58.0506181047190.2268@ppc970.osdl.org> <Pine.LNX.4.58.0506181105110.2268@ppc970.osdl.org> <Pine.LNX.4.58.0506181112590.2268@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262182AbVFRShA@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.58.0506181112590.2268@ppc970.osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:
> I'm hoping my earlier pulls on your trees haven't resulted in these kinds 
> of history losses before, and that this was the first time you did a merge 
> and didn't specify the parents properly. Pls confirm..

You're being overly paranoid :)

This netdev-2.6.git episode was the first time I ever tried to use the 
conflict merging.  I didn't know git had improved to the point where 
"git commit" without any arguments would actually get things right.

All the other merges used the vanilla git-pull-script with no 
modifications.  Presumably it does the right thing :)

	Jeff
