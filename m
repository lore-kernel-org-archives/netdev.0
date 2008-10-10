From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 2/4] tcpv6: trivial formatting changes to send_(ack|reset)
Date: Fri, 10 Oct 2008 15:00:39 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810100041380.14942@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0810091254160.1034@wrl-59.cs.helsinki.fi>
 <20081009141658.GB24905@ghostprotocols.net> <20081009.143859.113768989.davem@davemloft.net>
 <20081009.144053.86989787.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-542917344-1223588650=:14942"
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	yoshfuji@linux-ipv6.org, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58682 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754274AbYJJMAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 08:00:41 -0400
In-Reply-To: <20081009.144053.86989787.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0810101459250.1034@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-542917344-1223588650=:14942
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0810100044201.14942@wrl-59.cs.helsinki.fi>

On Thu, 9 Oct 2008, David Miller wrote:

> From: David Miller <davem@davemloft.net>
> Date: Thu, 09 Oct 2008 14:38:59 -0700 (PDT)
> 
> > From: Arnaldo Carvalho de Melo <acme@redhat.com>
> > Date: Thu, 9 Oct 2008 11:16:58 -0300
> > 
> > > Em Thu, Oct 09, 2008 at 12:58:07PM +0300, Ilpo Järvinen escreveu:
> > > > On Thu, 9 Oct 2008, YOSHIFUJI Hideaki / ???? wrote:
> > > > > I usually prefer sizeof(var) (or sizeof(*ptr)) over sizeof(type).
> > > > > Could you justify this change?
> > > > 
> > > > My point was to make those two functions as equal as possible before merge 
> > > > so that it's more easier to track what happens at the merge, both 
> > > > versions pre-existed anyway. Sure I don't have much opinion either way.
> > > 
> > > I agree with Yoshifuji, albeit it is unlikely that the type of that
> > > variable will change 8)
> > 
> > I agree as well

Ok. I keep this in mind in future (both versions pre-existed the
choice I made was just arbitary)... :-)

-- 
 i.
---696208474-542917344-1223588650=:14942--
