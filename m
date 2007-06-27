From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH 0/6] iw_cxgb3: Bug Fixes for 2.6.23
Date: Wed, 27 Jun 2007 12:14:44 -0700
Message-ID: <adafy4dryzf.fsf@cisco.com>
References: <20070627155119.24944.44172.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, divy@chelsio.com, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070627155119.24944.44172.stgit@dell3.ogc.int> (Steve Wise's
	message of "Wed, 27 Jun 2007 10:51:19 -0500")
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

 > Here are some bug fixes to the iw_cxgb3 driver that I'd like included
 > for 2.6.23. NOTE: Patch 1 requires a firmware interface change, so
 > there is a version bump to 4.3 included in that patch that hits cxgb3.
 > This will likely conflict with a previous version change that is in
 > Jeff's upstream branch.  The net is: we need the firmware version bumped
 > to 4.3 with these iw_cxgb3 changes.

OK, I'll probably pull this into my tree and hold off on asking Linus
to pull until after he pulls Jeff's net driver tree.  Once that
happens I'll fix up any conflicts and ask Linus to pull.
