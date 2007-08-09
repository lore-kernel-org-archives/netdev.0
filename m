From: Sean Hefty <mshefty@ichips.intel.com>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCP ports
	from the host TCP port space.
Date: Thu, 09 Aug 2007 14:40:16 -0700
Message-ID: <46BB89C0.4040303@ichips.intel.com>
References: <46B883B5.8040702@opengridcomputing.com>
	<46BB61D0.4090101@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	"David S. Miller" <davem@davemloft.net>,
	OpenFabrics General <general@lists.openfabrics.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46BB61D0.4090101@opengridcomputing.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Steve Wise wrote:
> Any more comments?

Does anyone have ideas on how to reserve the port space without using a 
struct socket?

- Sean
