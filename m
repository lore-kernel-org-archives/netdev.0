From: Ian McDonald <imcdnzl@gmail.com>
Subject: Re: KERNEL: assertion (!sk->sk_forward_alloc) failed
Date: Fri, 10 Feb 2006 08:25:49 +1300
Message-ID: <cbec11ac0602091125w5a5a7c6em8462131e9f9b24dc@mail.gmail.com>
References: <e282236e0602070146p1ed3fdb6k74aa75e15bbc37a3@mail.gmail.com>
	 <4807377b0602081207s7604eceahb8bf4af6715a6534@mail.gmail.com>
	 <43EB9548.9060504@kernelpanic.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Yoseph Basri <yoseph.basri@gmail.com>,
	linux-kernel@vger.kernel.org, NetDEV list <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750732AbWBITZw@vger.kernel.org>
To: bb@kernelpanic.ru
In-Reply-To: <43EB9548.9060504@kernelpanic.ru>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/10/06, Boris B. Zhmurov <bb@kernelpanic.ru> wrote:
> Hello, Jesse Brandeburg.
>
> On 08.02.2006 23:07 you said the following:
>
> > whats the relevance of e1000?
> >
> > I though Herbert had fixed these
>
> Nope :( I had this messages on 2.6.14.2 and now I have it on 2.6.15.3.
>
For what it's worth I had these messages for a while and they got
fixed 2 or 3 weeks ago from memory in Dave's 2.6.16 net tree or net2.6
tree.

Is it possible for you to download 2.6.16-rc2 or similar and see if it
goes away?

Ian
--
Ian McDonald
http://wand.net.nz/~iam4
WAND Network Research Group
University of Waikato
New Zealand
