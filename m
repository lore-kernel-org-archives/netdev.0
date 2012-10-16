From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [Bug 1063038] Re: Broadcom BCM57780 Cannot Connect at
 Gigabit Speed using tg3 module.
Date: Tue, 16 Oct 2012 08:29:44 -0700
Message-ID: <1350401384.8764.22.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <50756903.1030709@justinzane.com>
 <50774C61.9050207@justinzane.com>
 <0E685F8B314BFB42AE2422915B7BDCC30FDCEF86@IRVEXCHMB07.corp.ad.broadcom.com>
 <DAAFBCC105999F468732FA900576CB450FFA61A5@IRVEXCHMB08.corp.ad.broadcom.com>
 <5077BAAA.3070208@justinzane.com>
 <DAAFBCC105999F468732FA900576CB450FFAB4AF@IRVEXCHMB08.corp.ad.broadcom.com>
 <5078B151.9000607@justinzane.com> <5078B1EF.6090401@broadcom.com>
 <5078E7B8.20903@justinzane.com>
 <DAAFBCC105999F468732FA900576CB450FFBB033@IRVEXCHMB08.corp.ad.broadcom.com>
 <507CD7E6.7070102@justinzane.com> <507D66A3.1050703@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: "Justin Chudgar" <justin@justinzane.com>,
	"1063038@bugs.launchpad.net" <1063038@bugs.launchpad.net>,
	netdev@vger.kernel.org
To: "Nithin Sujir" <nsujir@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1552 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754728Ab2JPP3x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2012 11:29:53 -0400
In-Reply-To: <507D66A3.1050703@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-16 at 06:52 -0700, Nithin Sujir wrote: 
> "Per our record, this Acer system with BCM57780 and SSID:0601 was 
> intended by Acer to be a 10/100 system. The system is able to connect at 
> 10/100Mbps and therefore it is working as designed. Broadcom cannot 
> support any software/hardware request to override this built in design." 

With that being said, we'll update the tg3 driver to limit such systems
to use only 10/100 Mbps.
