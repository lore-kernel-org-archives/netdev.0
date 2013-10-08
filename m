From: Saurabh Mohan <saurabh.mohan@vyatta.com>
Subject: RE: [PATCH net] vti: get rid of nf mark rule in prerouting
Date: Tue, 8 Oct 2013 09:48:59 -0700
Message-ID: <1902752B0C92F943AB7EA9EE13E2DEEC1272BFA276@HQ1-EXCH02.corp.brocade.com>
References: <1381245682-15523-1-git-send-email-christophe.gouault@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: Christophe Gouault <christophe.gouault@6wind.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:52460 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753579Ab3JHRIS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Oct 2013 13:08:18 -0400
Received: from pps.filterd (m0000700 [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.14.5/8.14.5) with SMTP id r98G5rPR011327
	for <netdev@vger.kernel.org>; Tue, 8 Oct 2013 09:49:05 -0700
Received: from hq1wp-exchub02.corp.brocade.com ([144.49.131.13])
	by mx0b-000f0801.pphosted.com with ESMTP id 1fc1hn0qhm-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 08 Oct 2013 09:49:05 -0700
In-Reply-To: <1381245682-15523-1-git-send-email-christophe.gouault@6wind.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Christophe Gouault [mailto:christophe.gouault@6wind.com]
> Sent: Tuesday, October 08, 2013 8:21 AM
> To: netdev@vger.kernel.org
> Cc: David S. Miller; Cong Wang; Saurabh Mohan; Christophe Gouault
> Subject: [PATCH net] vti: get rid of nf mark rule in prerouting
> 
> This patch fixes and improves the use of vti interfaces (while lightly changing
> the way of configuring them).
> 

Good fix. Thanks for doing this!
