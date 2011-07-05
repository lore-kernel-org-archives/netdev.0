From: "Loke, Chetan" <Chetan.Loke@netscout.com>
Subject: RE: [RFC] non-preemptible kernel socket for RAMster
Date: Tue, 5 Jul 2011 12:36:43 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B91257D65C@nsmail.netscout.com>
References: <4232c4b6-15be-42d8-be42-6e27f9188ce2@default>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Konrad Wilk" <konrad.wilk@oracle.com>,
	"linux-mm" <linux-mm@kvack.org>
To: "Dan Magenheimer" <dan.magenheimer@oracle.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6og114.obsmtp.com ([64.18.1.33]:46913 "HELO
	exprod6og114.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753617Ab1GEQgq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 12:36:46 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4232c4b6-15be-42d8-be42-6e27f9188ce2@default>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Dan Magenheimer
> Sent: July 05, 2011 11:54 AM
> To: netdev@vger.kernel.org
> Cc: Konrad Wilk; linux-mm
> Subject: [RFC] non-preemptible kernel socket for RAMster
> 
> In working on a kernel project called RAMster* (where RAM on a
> remote system may be used for clean page cache pages and for swap
> pages), I found I have need for a kernel socket to be used when


How is RAMster+swap different than NBD's (pending etc?)support for SWAP
over NBD?


Chetan Loke

