From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Is TCP vulneribility patch (as in RFC 5961) done in linux?
Date: Mon, 16 Jul 2012 16:47:14 +0200
Message-ID: <1342450034.2830.6.camel@edumazet-glaptop>
References: <68700EDA775E5E47B5EBA9FF8AC0F15C076B03@SJEXCHMB09.corp.ad.broadcom.com>
	 <68700EDA775E5E47B5EBA9FF8AC0F15C077FF3@SJEXCHMB09.corp.ad.broadcom.com>
	 <1342427617.4812.0.camel@edumazet-glaptop>
	 <1342446411.23494.76.camel@edumazet-glaptop>
	 <68700EDA775E5E47B5EBA9FF8AC0F15C078898@SJEXCHMB09.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Kiran (Kiran Kumar) Kella" <kkiran@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:58234 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518Ab2GPOrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 10:47:19 -0400
Received: by eaak11 with SMTP id k11so1694545eaa.19
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 07:47:17 -0700 (PDT)
In-Reply-To: <68700EDA775E5E47B5EBA9FF8AC0F15C078898@SJEXCHMB09.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-16 at 13:50 +0000, Kiran (Kiran Kumar) Kella wrote:
> Eric,
> 
>   Thanks a lot for the patch.
> I shall try it out and let you know if I see any issues.

Please note followup patches are needed to address RFC 5961 Sections 4 &
5

(4 Blind Reset Attack Using the SYN Bit)
(5 Blind Data Injection Attack)
