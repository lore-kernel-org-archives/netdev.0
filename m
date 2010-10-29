From: Sjur BRENDELAND <sjur.brandeland@stericsson.com>
Subject: RE: [RFC net-next] caif: code cleanup
Date: Fri, 29 Oct 2010 11:36:25 +0200
Message-ID: <81C3A93C17462B4BBD7E272753C105791945A4EB6B@EXDCVYMBSTM005.EQ1STM.local>
References: <20101019095553.0b413b80@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andre Carvalho DE MATOS <andre.carvalho.matos@stericsson.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:40217 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756659Ab0J2Jgh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Oct 2010 05:36:37 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

> Stephen Hemminger wrote:
> >
> > Cleanup of new CAIF code.
> >   * make local functions static
> >   * remove code that is never used
> >   * expand get_caif_conf() since wrapper is no longer needed
> >   * make args to comparison functions const
> >   * rename connect_req_to_link_param to keep exported names
> >     consistent
> 
> Thank you for your patch.
> We'll try to test this sometime next week,
> and get back to you.

Sorry for taking so long to respond.
We have passed our tests on your RFC.
I'll ack this if you send a patch.

Regards,
Sjur

