From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH 0/26] Reliable Datagram Sockets (RDS),
	take 2
Date: Wed, 25 Feb 2009 13:45:12 -0800 (PST)
Message-ID: <20090225.134512.90879325.davem@davemloft.net>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
	<20090224.232814.227017310.davem@davemloft.net>
	<c0a09e5c0902251043x576e7066kb7aa76fc148a6f76@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: andy.grover@gmail.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <c0a09e5c0902251043x576e7066kb7aa76fc148a6f76@mail.gmail.com>
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

From: Andrew Grover <andy.grover@gmail.com>
Date: Wed, 25 Feb 2009 10:43:27 -0800

> RDS's reliable-datagram socket implementation has a modular interface
> to the transport (e.g. tcp, udp, or ib) and works fine over transports
> that do not support RDMA. (Most users also do not use RDMA.)

Ok, let me look over the patches again.
