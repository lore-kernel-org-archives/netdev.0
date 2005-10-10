From: Roland Dreier <rolandd@cisco.com>
Subject: Re: Timeline of IPoIB performance
Date: Mon, 10 Oct 2005 16:53:12 -0700
Message-ID: <527jcldj4n.fsf@cisco.com>
References: <1128672413.13948.326.camel@localhost> <52br20lsei.fsf@cisco.com>
	<1128738350.13945.369.camel@localhost> <521x2tgrim.fsf@cisco.com>
	<1128986707.13945.424.camel@localhost> <52br1xdjtm.fsf@cisco.com>
	<1128987897.13952.441.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Matt Leininger <mlleinin@hpcn.ca.sandia.gov>
In-Reply-To: <1128987897.13952.441.camel@localhost> (Matt Leininger's
	message of "Mon, 10 Oct 2005 16:44:57 -0700")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

    Matt>   Yes, I'm using mem-full HCAs.  I could try reflashing the
    Matt> firmware for memfree if that's of interest.

No, probably not.  If I get a chance I'll do the opposite (flash
mem-free -> mem-full, since my HCAs do have memory) and see if it
makes my results stable.
  
    Matt>  I was hoping someone else would do this.  :) I'll start
    Matt> working on it tomorrow if no one else gets to it.

I might get a chance to do it tonight... I'll post if I do.

 - R.
