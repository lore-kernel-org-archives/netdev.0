From: Shmulik Hen <shmulik.hen@intel.com>
Subject: Re: [bonding][0/3] Synchronizing 2.4-2.6
Date: Sat, 30 Aug 2003 22:05:45 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308302205.45924.shmulik.hen@intel.com>
References: <200308271958.52063.shmulik.hen@intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
In-Reply-To: <200308271958.52063.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 27 August 2003 07:58 pm, Hen, Shmulik wrote:
>
> Next in store are:
>  o Stephen Hemminger's converting bonding driver /proc interface to
>    seq_file, along with changing /proc/bond0/info to
>    /proc/bonding/bond0

Forgot to mention free_netdev().
Is it 2.4 compatible ?

>  o cleanup of the 802.3ad code (was not included in this release
> since it requires some code re-factoring first).
>  o lots of new stuff :)


-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
