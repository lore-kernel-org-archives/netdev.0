From: Mark Einon <mark.einon@gmail.com>
Subject: Re: [PATCH] linux-next: et131x: Fixups due to merge issues from
 staging tree
Date: Tue, 31 Jan 2012 19:09:31 +0000
Message-ID: <CANK3SE1w5n+t7+pwn6FLLu0py=-z2D=MSpWkg8ePKMdc2DfmrA@mail.gmail.com>
References: <20111025192636.f816c8860ee168a0a4756eda@canb.auug.org.au>
 <20111025121551.GA2108@marke.airties> <20120131182609.GA12819@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: 20111025192636.f816c8860ee168a0a4756eda@canb.auug.org.au,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120131182609.GA12819@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31 January 2012 18:26, Greg KH <greg@kroah.com> wrote:
> On Tue, Oct 25, 2011 at 01:15:52PM +0100, Mark Einon wrote:
>>
>> Manually merged changes from commits afc4b13df143, bf3f1a6081aa and 5d6bcdfe38ce into et131x.c as identified in email below.
>>
>> Also removed dependency on NETDEV_1000 in Kconfig, which no longer exists.
>>
>> Greg: This patch should also be good for the staging tree.
>
> I don't think this is needed anymore, right?

Hi Greg,

Correct, this change is in staging-next and does not need to be applied.
It's since been added by a merge from Linus's tree.

Cheers,

Mark

>
> If so, please redo it against Linus's tree and send it to me.
>
> thanks,
>
> greg k-h
