From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: netns patches WAS( Re: [PATCH 8/8] net: Implement socketat.
Date: Tue, 26 Oct 2010 17:27:47 -0700
Message-ID: <m1aam032f0.fsf@fess.ebiederm.org>
References: <m1ocborgq7.fsf@fess.ebiederm.org>
	<m1bp7oq1u8.fsf@fess.ebiederm.org> <4C9B162E.7040201@parallels.com>
	<1285240797.5036.5.camel@bigi> <4C9B3B06.900@parallels.com>
	<1285242055.5036.9.camel@bigi> <4C9B3F9C.8080506@parallels.com>
	<4CA7A07C.5030504@free.fr> <1286113441.3812.229.camel@bigi>
	<1287145855.3642.30.camel@bigi> <1288126326.2094.131.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <daniel.lezcano@free.fr>,
	Pavel Emelyanov <xemul@parallels.com>,
	linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Ulrich Drepper <drepper@gmail.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Ben Greear <greearb@candelatech.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>
To: hadi@cyberus.ca
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1288126326.2094.131.camel@mojatatu> (jamal's message of "Tue, 26
	Oct 2010 16:52:06 -0400")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal <hadi@cyberus.ca> writes:

> Eric,
>
> Ping?
> If you are too busy to push these in maybe have
> someone clueful like Daniel help out submitting? I think it
> should probably be reasonable to leave out the sockeat
> patch initially if it is deemed controversial..

This merge cycle I am too busy, and my patches did not make it into
linux-next before the merge window.

Everything except socketat at seems non-controversial.  socketat makes
sense to post-pone a little bit until we start converting applications,
and there is a little real world experience about what is needed.

I anticipate some time freeing up in the next couple of weeks so I
should be ready for the next merge window.

Eric
