From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] [PATCH 2.6.26 1/3] RDMA/cxgb3: Correctly serialize
	peer abort path.
Date: Mon, 28 Apr 2008 15:47:27 -0700
Message-ID: <adahcdlzjeo.fsf@cisco.com>
References: <20080427155456.31018.22282.stgit@dell3.ogc.int>
	<20080427160006.31018.66715.stgit@dell3.ogc.int>
	<adaprs9zjjy.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, divy@chelsio.com, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adaprs9zjjy.fsf@cisco.com> (Roland Dreier's message of "Mon, 28
	Apr 2008 15:44:17 -0700")
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

oh yeah, and I deleted an unused "out" label
