From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH 0/6] SUNRPC: make RPC clients use network-namespace-aware
 PipeFS routines
Date: Wed, 23 Nov 2011 21:18:41 +0400
Message-ID: <4ECD2AF1.9090101@parallels.com>
References: <20111123104945.11077.10270.stgit@localhost6.localdomain6> <20111123162711.GA30672@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	James Bottomley <jbottomley@parallels.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111123162711.GA30672@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

23.11.2011 20:27, J. Bruce Fields =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Wed, Nov 23, 2011 at 02:51:10PM +0300, Stanislav Kinsbursky wrote:
>> This patch set was created in context of clone of git
>> branch: git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git.
>> tag: v3.1
>>
>> This patch set depends on previous patch sets titled:
>> 1) "SUNRPC: initial part of making pipefs work in net ns"
>> 2) "SUNPRC: cleanup PipeFS for network-namespace-aware users"
>
> Do you have a git tree set up with all of these applied?
>

I have, but no external access to it yet.

> (If I want to take a quick look it would personally be easier for me =
to
> fetch your git tree than to get those patches out of old email.)
>

Will check tomorrow, is it possible to organize it.

> --b.
>


--=20
Best regards,
Stanislav Kinsbursky
