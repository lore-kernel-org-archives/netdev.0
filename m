From: Ian McDonald <imcdnzl@gmail.com>
Subject: Re: KERNEL: assertion (!sk->sk_forward_alloc) failed
Date: Fri, 10 Feb 2006 08:37:48 +1300
Message-ID: <cbec11ac0602091137p4ee233bdgdcfbf3d6cb62a62f@mail.gmail.com>
References: <e282236e0602070146p1ed3fdb6k74aa75e15bbc37a3@mail.gmail.com>
	 <4807377b0602081207s7604eceahb8bf4af6715a6534@mail.gmail.com>
	 <43EB9548.9060504@kernelpanic.ru>
	 <cbec11ac0602091125w5a5a7c6em8462131e9f9b24dc@mail.gmail.com>
	 <43EB98B0.4@kernelpanic.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Yoseph Basri <yoseph.basri@gmail.com>,
	linux-kernel@vger.kernel.org, NetDEV list <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750738AbWBIThx@vger.kernel.org>
To: bb@kernelpanic.ru
In-Reply-To: <43EB98B0.4@kernelpanic.ru>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/10/06, Boris B. Zhmurov <bb@kernelpanic.ru> wrote:
> Hello, Ian McDonald.
>
> On 09.02.2006 22:25 you said the following:
>
> > Is it possible for you to download 2.6.16-rc2 or similar and see if it
> > goes away?
>
> It'll be better, if I get only patch fixs that problem, not all 2.6.16-rc2.
>
Oops I didn't read Jesse's message earlier properly.

That patch which probably fixed it is (from his message):
I think the commit id that is missing from 2.6.14.X is
fb5f5e6e0cebd574be737334671d1aa8f170d5f3

but here is the web link if i gave the wrong info
http://www.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=fb5f5e6e0cebd574be737334671d1aa8f170d5f3
--
Ian McDonald
http://wand.net.nz/~iam4
WAND Network Research Group
University of Waikato
New Zealand
