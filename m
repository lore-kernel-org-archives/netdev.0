From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: net: panic when removing device due to vrf
Date: Thu, 1 Oct 2015 16:51:25 -0600
Message-ID: <560DB8ED.5080609@cumulusnetworks.com>
References: <560DB8BA.9020700@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <560DB8BA.9020700@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/1/15 4:50 PM, Sasha Levin wrote:
> Hi David,
>
> Commit 93a7e7e837 ("net: Remove the now unused vrf_ptr") is causing a panic whenever
> I unplug a network device:

Cong just sent a patch. Sorry for the trouble.
