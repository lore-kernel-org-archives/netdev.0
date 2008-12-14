From: Sujith <m.sujith@gmail.com>
Subject: BUG - ath9k keep on disconnecting in 2.6.28-rc8
Date: Sun, 14 Dec 2008 13:39:26 +0530
Message-ID: <18756.48950.20615.440764@localhost.localdomain>
References: <3f9a31f40812132354k6f9e7b80o30d3236687dffba0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, jmalinen@atheros.com,
	ath9k-devel@lists.ath9k.org
To: "Jaswinder Singh" <jaswinderlinux@gmail.com>
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
In-Reply-To: <3f9a31f40812132354k6f9e7b80o30d3236687dffba0@mail.gmail.com>
List-Unsubscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=unsubscribe>
List-Archive: <http://lists.ath9k.org/pipermail/ath9k-devel>
List-Post: <mailto:ath9k-devel@lists.ath9k.org>
List-Help: <mailto:ath9k-devel-request@lists.ath9k.org?subject=help>
List-Subscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=subscribe>
Sender: ath9k-devel-bounces@lists.ath9k.org
Errors-To: ath9k-devel-bounces@lists.ath9k.org
List-Id: netdev.vger.kernel.org

Jaswinder Singh wrote:
> I am facing problem with 2.6.28-rc8, ath9k keep on disconnecting.

[...]

> wlan0: authenticate with AP 00:11:95:9e:df:f6
> ForceXPAon: 0
> wlan0: authenticate with AP 00:11:95:9e:df:f6
> wlan0: authenticate with AP 00:11:95:9e:df:f6
> wlan0: authenticate with AP 00:11:95:9e:df:f6
> wlan0: authentication with AP 00:11:95:9e:df:f6 timed out

A number of updates have gone into the wireless-testing tree.
You can use that tree or compat-wireless to get the latest driver
and check if the problem persists.

Sujith
