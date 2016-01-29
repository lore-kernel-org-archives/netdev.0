From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH net-next 0/3] sctp: add GSO support
Date: Fri, 29 Jan 2016 16:07:12 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCD11E0@AcuExch.aculab.com>
References: <cover.1453913331.git.marcelo.leitner@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCCEDE4@AcuExch.aculab.com>
 <20160128155323.GB6602@mrl.redhat.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCD0160@AcuExch.aculab.com>
 <20160128205551.GC6602@mrl.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>,
	"brouer@redhat.com" <brouer@redhat.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
	"borkmann@iogearbox.net" <borkmann@iogearbox.net>,
	"marek@cloudflare.com" <marek@cloudflare.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"pabeni@redhat.com" <pabeni@redhat.com>,
	"john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: 'Marcelo Ricardo Leitner' <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.191]:58377 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756550AbcA2QKT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 11:10:19 -0500
In-Reply-To: <20160128205551.GC6602@mrl.redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: 'Marcelo Ricardo Leitner' [mailto:marcelo.leitner@gmail.com]
> Sent: 28 January 2016 20:56
...
> > > But yes, agreed, MSG_MORE is at least a welcomed compliment here,
> > > specially for applications generating a train of chunks. Will put that in
> > > my ToDo here, thanks.
> >
> > I've posted a patch in the past for MSG_MORE, didn't quite work.
> 
> Ahh cool. Can you share the archive link please? Maybe I can take it
> from there then.

I think the last record is:
https://patchwork.ozlabs.org/patch/372404

	David
