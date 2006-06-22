From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 2/7] NetLabel: core network changes
Date: Thu, 22 Jun 2006 14:32:55 -0700 (PDT)
Message-ID: <20060622.143255.63999137.davem@davemloft.net>
References: <20060621200030.880930000@flek.zko.hp.com>
	<20060622.020055.115910616.davem@davemloft.net>
	<200606221105.00331.sgrubb@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, paul.moore@hp.com, sds@epoch.ncsc.mil,
	redhat-lspp@redhat.com, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, netdev@vger.kernel.org
Return-path: <redhat-lspp-bounces@redhat.com>
To: sgrubb@redhat.com
In-Reply-To: <200606221105.00331.sgrubb@redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/redhat-lspp>,
	<mailto:redhat-lspp-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/redhat-lspp>
List-Post: <mailto:redhat-lspp@redhat.com>
List-Help: <mailto:redhat-lspp-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/redhat-lspp>,
	<mailto:redhat-lspp-request@redhat.com?subject=subscribe>
Sender: redhat-lspp-bounces@redhat.com
Errors-To: redhat-lspp-bounces@redhat.com
List-Id: netdev.vger.kernel.org

From: Steve Grubb <sgrubb@redhat.com>
Date: Thu, 22 Jun 2006 11:05:00 -0400

> If moving this over to generic is a must, then I think SE Linux will
> have to clip into generic to control its packet flow.

James Morris has already started discussions on this.
It's great that there will be another reason why that work
needs to be done :)
