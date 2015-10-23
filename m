From: Ariel Elior <Ariel.Elior@qlogic.com>
Subject: RE: [BUG] bnx2x_config_vlan_mac called a NULL function pointer
Date: Fri, 23 Oct 2015 08:16:01 +0000
Message-ID: <81D78EA7F834FA4C83B64260D494C859087952A8@avmb3.qlogic.org>
References: <20151022194509.GA14434@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Adam Okuliar <aokuliar@redhat.com>,
	Jirka Hladky <jhladky@redhat.com>
To: Otto Sabart <osabart@redhat.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:52265 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751412AbbJWIQG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 04:16:06 -0400
In-Reply-To: <20151022194509.GA14434@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looking into it...

> -----Original Message-----
> From: Otto Sabart [mailto:osabart@redhat.com]
> Sent: Thursday, October 22, 2015 10:45 PM
> To: netdev <netdev@vger.kernel.org>
> Cc: Ariel Elior <Ariel.Elior@qlogic.com>; Adam Okuliar <aokuliar@redhat.com>; Jirka
> Hladky <jhladky@redhat.com>
> Subject: [BUG] bnx2x_config_vlan_mac called a NULL function pointer
> 
> Hello netdev,
> I probably found a bug in kernel-4.3.0-0.rc5 (bnx2x driver). So I opened
> new bug report in our bugzilla [0]. Michal Schmidt told me the best way
> to solve an upstream bug is to contact you directly to netdev list.. so
> here I am :).
> 
> Can somebody take a look at it?
> 
> [0] https://bugzilla.redhat.com/show_bug.cgi?id=1273894
> 
> 
> thanks,
> 
> Ota
