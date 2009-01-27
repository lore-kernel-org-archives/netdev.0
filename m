From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH 01/21] RDS: Socket interface
Date: Mon, 26 Jan 2009 20:11:04 -0800 (PST)
Message-ID: <20090126.201104.33429150.davem@davemloft.net>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
	<1233022678-9259-2-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: andy.grover@oracle.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1233022678-9259-2-git-send-email-andy.grover@oracle.com>
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


Socket family implementations do not belong under the
infiniband subdirectory.

Put it under net/ instead.

I don't care what the interdependencies happen to be.
