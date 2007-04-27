From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH 2.6.22 5/5] iw_cxgb3: Update required
	firmware revision to 4.0.0.
Date: Thu, 26 Apr 2007 20:12:42 -0700
Message-ID: <adaps5qo6hh.fsf@cisco.com>
References: <20070426202057.24234.56383.stgit@dell3.ogc.int>
	<20070426202126.24234.71523.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org, divy@chelsio.com,
	jeff@garzik.org, linux-kernel@vger.kernel.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070426202126.24234.71523.stgit@dell3.ogc.int> (Steve Wise's
	message of "Thu, 26 Apr 2007 15:21:26 -0500")
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

 > Update required firmware revision to 4.0.0.

Hmm... should we fold this into the earlier patch, which actually
needs this new FW?  Or at least merge this patch first?

Also, is it cool with everyone to require a new FW, even for users who
might not be using (or even building) the RDMA driver?  I'm not sure
what a good solution would be really, so maybe the pain of forcing
everyone to update FW is the least bad thing to do.

 - R.
