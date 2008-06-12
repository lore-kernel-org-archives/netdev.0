From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [ofa-general] Re: [PATCH v4 14/14] QLogic VNIC: sysfs
	Documentation
Date: Thu, 12 Jun 2008 16:22:24 -0400
Message-ID: <48518580.7010206@garzik.org>
References: <20080610205633.11186.45499.stgit@dale>	
	<20080610210918.11186.64253.stgit@dale>
	<484F751F.7030407@trash.net>	
	<c8028d330806120813q6363c3cemb4aa03ceff6547d1@mail.gmail.com>	
	<48513E4E.4040601@trash.net>
	<71d336490806120829o7cac67bes384c305e03b0d746@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Amar Mudrankit <amar.mudrankit@qlogic.com>, netdev@vger.kernel.org,
	rdreier@cisco.com, general@lists.openfabrics.org,
	Patrick McHardy <kaber@trash.net>, poornima.kamath@qlogic.com
To: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <71d336490806120829o7cac67bes384c305e03b0d746@mail.gmail.com>
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

Ramachandra K wrote:
> If you are referring to IP address configuration etc, users can configure
> the interfaces by setting up ifcfg files and the interfaces are automatically
> configured when they are registered.


That makes a lot of assumptions about the Linux distribution and 
userspace setup, assumptions that may not be true for all Linux.

	Jeff
