From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH 01/11] IB/ipoib: Export call to
	call_netdevice_notifiers and add new private flag
Date: Mon, 17 Sep 2007 15:17:14 -0700
Message-ID: <adabqc1lyxh.fsf@cisco.com>
References: <11898132301664-git-send-email-fubar@us.ibm.com>
	<11898132322950-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org, jgarzik@pobox.com,
	davem@davemloft.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <11898132322950-git-send-email-fubar@us.ibm.com> (Jay Vosburgh's
	message of "Fri, 14 Sep 2007 16:40:20 -0700")
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

I tried to look at the ipoib stuff in this series... this patch looks
fine but it doesn't actually touch ipoib, so the subject line is a bit
misleading...
