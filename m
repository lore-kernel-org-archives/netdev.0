From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/5] rfkill-gpio: ACPI support
Date: Thu, 17 Oct 2013 16:26:30 +0200
Message-ID: <1382019990.14410.5.camel@jlt4.sipsolutions.net>
References: <1381920823-15403-1-git-send-email-heikki.krogerus@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Rhyland Klein <rklein@nvidia.com>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	linux-acpi@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1381920823-15403-1-git-send-email-heikki.krogerus@linux.intel.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-10-16 at 13:53 +0300, Heikki Krogerus wrote:
> Hi,
> 
> The first patches prepare the driver for the support. The last patch
> can then add the support quite easily. With these patches, adding DT
> support later will be quite straight forward if someone needs it.

Applied. I'm totally relying on all the reviewers though, since I have
very little idea of what's going on. If anyone else wants to maintain
the rfkill-gpio driver I'd welcome that :-)

johannes

