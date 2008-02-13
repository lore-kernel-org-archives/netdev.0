From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] [PATCH 2.6.25] RDMA/cxgb3: Fail loopbackconnections.
Date: Wed, 13 Feb 2008 07:46:17 -0800
Message-ID: <adaskzwuaeu.fsf@cisco.com>
References: <20080212220929.24442.76874.stgit@dell3.ogc.int>
	<adafxvxvgz3.fsf@cisco.com> <015c01c86e21$75317210$05c8a8c0@DIEGO>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: "Diego Guella" <diego.guella@sircomtech.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <015c01c86e21$75317210$05c8a8c0@DIEGO> (Diego Guella's message of
	"Wed, 13 Feb 2008 10:18:53 +0100")
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

  > how can a static void function return 0?

good question... I've fixed the patch in my tree.
