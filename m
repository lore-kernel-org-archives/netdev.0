From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] sctp: Export sctp_do_peeloff
Date: Thu, 08 Mar 2012 13:52:35 -0800 (PST)
Message-ID: <20120308.135235.216702729705858755.davem@davemloft.net>
References: <20120308.002447.1062706659978103072.davem@davemloft.net>
	<1331222159-28980-1-git-send-email-bpoirier@suse.de>
	<4F59118C.9090605@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bpoirier@suse.de, ccaulfie@redhat.com, teigland@redhat.com,
	sri@us.ibm.com, cluster-devel@redhat.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F59118C.9090605@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Date: Thu, 08 Mar 2012 15:07:40 -0500

> On 03/08/2012 10:55 AM, Benjamin Poirier wrote:
>> lookup sctp_association within sctp_do_peeloff() to enable its use outside of
>> the sctp code with minimal knowledge of the former.
>> 
>> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
>> 
> 
> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied to net-next.
