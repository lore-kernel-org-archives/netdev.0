From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/4] vbus: venet macvlan support
Date: Thu, 12 Nov 2009 16:59:20 +0100
Message-ID: <4AFC30D8.4050506@trash.net>
References: <20091110222632.24100.14884.stgit@mimic.site> <4AFC2D65.9040903@gmail.com> <4AFC2F71.1060408@trash.net> <4AFC2FCC.5090103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Patrick Mullaney <pmullaney@novell.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, arnd@arndb.de,
	bridge@lists.linux-foundation.org, evb@yahoogroups.com,
	netdev@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753412AbZKLPzv@vger.kernel.org>
In-Reply-To: <4AFC2FCC.5090103@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gregory Haskins wrote:
> Patrick McHardy wrote:
>> Gregory Haskins wrote:
>>> Patrick Mullaney wrote:
>>>> (Applies to alacrityvm.git/master:34534534)
>>>>
>>>> This patchset implements a vbus venet device with a
>>>> macvlan backend.
>>> Thanks Pat, applied.
>> As I mentioned in my response to these patches, the macvlan part
>> need more work.
> 
> Yeah, I talked to Pat offline.  He is going to patch it incrementally as
> its not a trivial problem to cleanup.  For the time being, they are
> sitting in the alacrityvm tree, but they are not going upstream until
> the macvlan stuff is resolved.

I see, thanks.
