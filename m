From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net 1/2] net: introduce device min_header_len
Date: Tue, 7 Feb 2017 13:24:09 -0800
Message-ID: <20170207212409.GA9927@oracle.com>
References: <20170207205721.23207-1-willemdebruijn.kernel@gmail.com>
 <20170207205721.23207-2-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        eric.dumazet@gmail.com, dvyukov@google.com,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:27009 "EHLO
        userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754367AbdBGV1J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 16:27:09 -0500
Received: from userp1040.oracle.com (userp1040.oracle.com [156.151.31.81])
        by userp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v17LPVLB030807
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Tue, 7 Feb 2017 21:25:31 GMT
Content-Disposition: inline
In-Reply-To: <20170207205721.23207-2-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (02/07/17 15:57), Willem de Bruijn wrote:
> 
> From: Willem de Bruijn <willemb@google.com>
> 
> The stack must not pass packets to device drivers that are shorter
> than the minimum link layer header length.

Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
