From: Ralph Doncaster <ralph@istop.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 19:58:47 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.51.0306101956520.7801@ns.istop.com>
References: <16102.9418.43884.336925@robur.slu.se> <20030610.115759.26513736.davem@redhat.com>
 <Pine.LNX.4.51.0306101725020.17226@ns.istop.com> <20030610.152020.59678979.davem@redhat.com>
Reply-To: ralph+d@istop.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Robert.Olsson@data.slu.se" <Robert.Olsson@data.slu.se>,
	"hadi@shell.cyberus.ca" <hadi@shell.cyberus.ca>,
	"xerox@foonet.net" <xerox@foonet.net>,
	"sim@netnation.com" <sim@netnation.com>,
	"fw@deneb.enyo.de" <fw@deneb.enyo.de>,
	"netdev@oss.sgi.com" <netdev@oss.sgi.com>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030610.152020.59678979.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Tue, 10 Jun 2003, David S. Miller wrote:

>    From: Ralph Doncaster <ralph@istop.com>
>    What's the do_gettimeofday for?
>
> Every packet records a timestamp.

I'm not aware of anything in IP routing that requires a timestamp for
every packet.  To me it sounds like we could rip that out too.

-Ralph

