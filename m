From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH v4 7/9] rdma/cm: Add helper functions to return id address
 information
Date: Wed, 13 Feb 2013 14:44:09 +0200
Message-ID: <511B8A99.70607@mellanox.com>
References: <1358891797-14625-1-git-send-email-sean.hefty@intel.com> <1358891797-14625-8-git-send-email-sean.hefty@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>
To: <sean.hefty@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:38721 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754409Ab3BMMoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 07:44:19 -0500
In-Reply-To: <1358891797-14625-8-git-send-email-sean.hefty@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/01/2013 23:56, sean.hefty@intel.com wrote:
> Provide inline helpers to extract source and destination address data from the rdma_cm_id.

Sean,

FWIW - this patch and most of patch #6 can (and worth doing) be 
introduced as cleanup/maintenance patches to the rdma-cm without direct 
relation to the AF_IB effort.

Or.
