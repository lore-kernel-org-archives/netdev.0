From: Moni Shoua <monis@Voltaire.COM>
Subject: [ofa-general] Where is the right place to add monitoring data
Date: Wed, 01 Apr 2009 16:37:59 +0300
Message-ID: <49D36E37.6060308@Voltaire.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	OpenFabrics General <general@lists.openfabrics.org>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
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

Hi,
I want to add data monitoring capabilities to rdma_cm (socket like interface that does connection management for InfiniBand and iWarp protocols).
My question is: will it be acceptable to create a new enrty /proc/net/rdma_cm or is is /proc file system really closed for new members.
I get opinions for here and there and I'd like to get yours.

thanks
 MoniS
