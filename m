From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] [PATCH 2.6.26 3/3] RDMA/cxgb3: Support peer-2-peer
	connection setup.
Date: Sun, 27 Apr 2008 09:34:00 -0700
Message-ID: <adatzhn2r5z.fsf@cisco.com>
References: <20080427155456.31018.22282.stgit@dell3.ogc.int>
	<20080427160010.31018.67436.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org,
	linux-kernel@vger.kernel.org, divy@chelsio.com
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080427160010.31018.67436.stgit@dell3.ogc.int> (Steve Wise's
	message of "Sun, 27 Apr 2008 11:00:10 -0500")
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

What are the interoperability implications of this?

Looking closer I see that iw_nes has the send_first module parameter.
How does this interact with that?

I guess it's fine to apply this, but do we have a plan for how we want
to handle this issue in the long-term?

 - R.
