From: Arjan van de Ven <arjan@fenrus.demon.nl>
Subject: Re: [patch 2.6.9 0/11] Add MODULE_VERSION to several network
	drivers
Date: Thu, 21 Oct 2004 11:17:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098350269.2810.17.camel@laptop.fenrus.com>
References: <20041020141146.C8775@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, jgarzik@pobox.com,
        davem@davemloft.net, john.ronciak@intel.com,
        ganesh.venkatesan@intel.com, akpm@osdl.org, romieu@fr.zoreil.com,
        ctindel@users.sourceforge.net, fubar@us.ibm.com,
        greearb@candelatech.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20041020141146.C8775@tuxdriver.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-10-20 at 20:11, John W. Linville wrote:
> Patches to add MODULE_VERSION lines to several network drivers...
> 
> Here is the list:

have you checked if the version of these drivers is actually useful? (eg
updated when the driver changes) If it's not I'd say adding a
MODULE_VERSION to it makes no sense whatsoever.
