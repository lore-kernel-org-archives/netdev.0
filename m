From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] [PATCH 2.6.25] RDMA/cxgb3: Shift calculation wrong
	for single sge entries.
Date: Mon, 25 Feb 2008 14:29:34 -0800
Message-ID: <ada63wczn3l.fsf@cisco.com>
References: <20080220233148.25301.54457.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080220233148.25301.54457.stgit@dell3.ogc.int> (Steve Wise's
	message of "Wed, 20 Feb 2008 17:31:48 -0600")
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

Thanks, applied, although I assume based on the Signed-off-by line
that you left out a

  From: Bryan Rosenburg <rosnbrg@us.ibm.com>

at the top (to get the authorship in git correctly).

 > RDMA/cxgb3: Shift calculation wrong for single sge entries.

BTW, there's no need to duplicate the subject line in the message
body, but if you are going to do it, please put a "Subject:" before
it.  Otherwise I just have to edit it out by hand to avoid git putting
the subject in twice.

 - R.
