From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: SCTP sockopt discrepancy between 2.4 and 2.6.
Date: Tue, 3 Feb 2004 10:13:54 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402031008120.2060@localhost.localdomain>
References: <1075747382.786.366.camel@hades.cambridge.redhat.com>
 <Pine.LNX.4.58.0402021056290.2352@localhost.localdomain>
 <20040202112150.3c8d5218.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: dwmw2@infradead.org, netdev@oss.sgi.com, marcelo.tosatti@cyclades.com,
        lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040202112150.3c8d5218.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2 Feb 2004, David S. Miller wrote:

>
> I appreciate your status report Sridhar, thank you.
>
> But the fact of the matter is that 2.4.x and 2.6.x cannot export two
> totally incompatible user visible APIs for the SCTP socket layer.
>
> This is something which must be fixed, not something we would like to
> be fixed :-)

I contacted the team that started the 2.4 backport and we will try to fix
this in the next few weeks so that 2.4 lksctp is in sync 2.6. Hopefully
this will happen by 2.4.26.

Thanks
Sridhar
