From: David Miller <davem@davemloft.net>
Subject: Re: [net] e1000: Fix driver to be used on PA RISC C8000
 workstations
Date: Tue, 30 Aug 2011 20:39:03 -0400 (EDT)
Message-ID: <20110830.203903.2196937547187204637.davem@davemloft.net>
References: <1314749966-9960-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org, gmsoft@tuxicoman.be,
        gospo@redhat.com, eike-kernel@sf-tec.de, mattst88@gmail.com
To: jeffrey.t.kirsher@intel.com
Return-path: <stable-bounces@linux.kernel.org>
In-Reply-To: <1314749966-9960-1-git-send-email-jeffrey.t.kirsher@intel.com>
List-Unsubscribe: <http://linux.kernel.org/mailman/options/stable>,
 <mailto:stable-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/mailman/private/stable/>
List-Post: <mailto:stable@linux.kernel.org>
List-Help: <mailto:stable-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/stable>,
 <mailto:stable-request@linux.kernel.org?subject=subscribe>
Sender: stable-bounces@linux.kernel.org
Errors-To: stable-bounces@linux.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 30 Aug 2011 17:19:26 -0700

> +#ifdef __hppa__

Please use CONFIG_PARISC

_______________________________________________
stable mailing list
stable@linux.kernel.org
http://linux.kernel.org/mailman/listinfo/stable
