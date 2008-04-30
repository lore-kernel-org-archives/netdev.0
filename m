From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH 00/13] QLogic Virtual NIC (VNIC) Driver
Date: Wed, 30 Apr 2008 15:25:40 -0700
Message-ID: <adamynb6kuz.fsf@cisco.com>
References: <20080430171028.31725.86190.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, poornima.kamath@qlogic.com,
	general@lists.openfabrics.org, amar.mudrankit@qlogic.com
To: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080430171028.31725.86190.stgit@localhost.localdomain>
	(Ramachandra K.'s message of "Wed, 30 Apr 2008 22:45:52 +0530")
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

 > This is the QLogic Virtual NIC driver patch series which has been tested
 > against your for-2.6.26 and for-2.6.27 branches. We intended these patches to
 > make it to the 2.6.26 kernel, but if it is too late for the 2.6.26 merge window
 > please consider them for 2.6.27.

Yes, *WAY* too late for 2.6.26, given that today is the last day of the
merge window, and that things that get merged need to be ready before
the merge window opens.

 > The driver compiles cleanly with sparse endianness checking enabled. We have
 > also tested the driver with lockdep checking enabled.
 > 
 > We have run these patches through checkpatch.pl and the only warnings are
 > related to lines slightly longer than 80 columns in some of the statements.

All good news.

Will review and I hope get this into 2.6.27.

 - R.
