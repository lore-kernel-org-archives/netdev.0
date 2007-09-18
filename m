From: Tziporet Koren <tziporet@dev.mellanox.co.il>
Subject: Re: [ofa-general] InfiniBand/RDMA merge plans for 2.6.24
Date: Tue, 18 Sep 2007 11:48:38 +0200
Message-ID: <46EF9EF6.7090805@mellanox.co.il>
References: <adahclymos8.fsf@cisco.com>	<000401c7f632$c993e8e0$65cc180a@amr.corp.intel.com> <1190034015.6272.83.camel@hrosenstock-ws.xsigo.com>
Reply-To: tziporet@dev.mellanox.co.il
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sean Hefty <sean.hefty@intel.com>, netdev@vger.kernel.org,
	'Roland Dreier' <rdreier@cisco.com>,
	linux-kernel@vger.kernel.org, general@lists.openfabrics.org
To: Hal Rosenstock <hrosenstock@xsigo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:9208 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754672AbXIRJpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 05:45:52 -0400
Received: by ug-out-1314.google.com with SMTP id z38so60476ugc
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 02:45:50 -0700 (PDT)
In-Reply-To: <1190034015.6272.83.camel@hrosenstock-ws.xsigo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hal Rosenstock wrote:
>
> Has anyone tested these with QoS actually be used ? I suppose this
> requires Connect-X.
>   

You can test it with a switch without ConnectX.
If you want that the HCA will react to the QoS setting too then you 
should have ConnectX



Tziporet
