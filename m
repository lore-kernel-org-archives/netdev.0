From: Toan Pham <tpham3783@gmail.com>
Subject: Re: [Problem] broadcom tg3 network driver disconnects under high load
Date: Tue, 28 Apr 2015 14:53:50 -0400
Message-ID: <CAGNmLEN+uMA=7JEXj+S_Pevi1O1UhToFTnDvUc5dtEY-fudesw@mail.gmail.com>
References: <CAGNmLEMbyR6-1WSyPRZQhLanH_UB7xb5cVVQ9N625bvdhbA6MA@mail.gmail.com>
	<1429908991.3920.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<CAGNmLEMB-hpG_TW3qQGbiHM2Vfd30P=D5H3_ioeY56+iKt14hA@mail.gmail.com>
	<1430244665.6888.26.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: sanjeevb@broadcom.com, prashant@broadcom.com,
	netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:33981 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030524AbbD1Sxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 14:53:51 -0400
Received: by iedfl3 with SMTP id fl3so28846929ied.1
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 11:53:50 -0700 (PDT)
In-Reply-To: <1430244665.6888.26.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  Do you have PCIE Advanced Error Reporting (CONFIG_PCIEAER) enabled in
your kernel?

Yes, it is enabled.
