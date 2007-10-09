From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCHES] TX batching rev2.5
Date: Tue, 09 Oct 2007 18:20:26 -0400
Message-ID: <1191968426.5324.45.camel@localhost>
References: <1191967639.5324.25.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jeff@garzik.org, mchan@broadcom.com, general@lists.openfabrics.org,
	kumarkr@linux.ibm.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.226]:1515 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459AbXJIWUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 18:20:34 -0400
Received: by wx-out-0506.google.com with SMTP id h31so11838wxd
        for <netdev@vger.kernel.org>; Tue, 09 Oct 2007 15:20:33 -0700 (PDT)
In-Reply-To: <1191967639.5324.25.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-09-10 at 18:07 -0400, jamal wrote:
> Please provide feedback on the code and/or architecture.
> They are now updated to work with the latest rebased net-2.6.24 
> from a few hours ago.

I should have added i have tested this with just the batching changes
and it is within the performance realm of the changes from yesterday. If
anyone wants exact numbers, i can send them.

cheers,
jamal

