From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Fri, 27 Jun 2003 07:59:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030627075946.7ab6f591.shemminger@osdl.org>
References: <20030625.143334.85380461.davem@redhat.com>
	<20030626035824.D68B62C147@lists.samba.org>
	<20030625.205941.41631020.davem@redhat.com>
	<16122.53298.150512.793074@h006008986325.ne.client2.attbi.com>
	<20030626190407.S87648@shell.cyberus.ca>
	<16124.11495.374998.153330@h006008986325.ne.client2.attbi.com>
	<16124.13469.944716.441016@nanango.paulus.ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: carlson@workingcode.com, hadi@shell.cyberus.ca, davem@redhat.com,
   rusty@rustcorp.com.au, netdev@oss.sgi.com, fcusack@samba.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Paul Mackerras <paulus@samba.org>
In-Reply-To: <16124.13469.944716.441016@nanango.paulus.ozlabs.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 27 Jun 2003 22:12:13 +1000 (EST)
Paul Mackerras <paulus@samba.org> wrote:

> James Carlson writes:
> > Jamal Hadi writes:
> > > So what about packet being loss? Wouldnt that ensure reordering?
> > 
> > Please explain.  What pattern of loss possibly results in one packet
> > being inserted in the stream ahead of another?
> 
> Rusty asked me today what protocols there were that coped with packet
> loss but couldn't cope with reordering.  I couldn't think of any.  Do
> you know of any examples?
> 

Does LLC allow for re-ordering?
