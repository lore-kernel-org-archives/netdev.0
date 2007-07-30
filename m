From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH 2.6.23 1/2] Make the iw_cxgb3 module
	parameters writable.
Date: Mon, 30 Jul 2007 13:20:21 -0700
Message-ID: <adad4y9skxm.fsf@cisco.com>
References: <20070729201226.31659.85900.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070729201226.31659.85900.stgit@dell3.ogc.int> (Steve Wise's
	message of "Sun, 29 Jul 2007 15:12:26 -0500")
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

ugh, missed these before my last merge...

anyway:

why do we want to parameters writable?  a good changelog tells me
what, why and how, and this changelog just covered the "what".  Also,
I assume you've checked that it's OK for these variables to change at
any time?
