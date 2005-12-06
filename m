From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 12/14] spidernet: check if firmware was loaded correctly
Date: Tue, 6 Dec 2005 11:23:39 +0100
Message-ID: <200512061123.40059.arnd@arndb.de>
References: <20051206035220.097737000@localhost>
	<20051206040645.193163000@localhost>
	<17300.57951.373636.507621@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linuxppc64-dev@ozlabs.org, netdev@vger.kernel.org,
	Jens.Osterkamp@de.ibm.com
Return-path: <linuxppc64-dev-bounces@ozlabs.org>
To: Paul Mackerras <paulus@samba.org>
In-Reply-To: <17300.57951.373636.507621@cargo.ozlabs.ibm.com>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces@ozlabs.org
Errors-To: linuxppc64-dev-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

On Dinsdag 06 Dezember 2005 01:59, Paul Mackerras wrote:
> Arnd Bergmann writes:
> 
> > Uploading the device firmware may fail if wrong input data
> > was provided by the user. This checks for the condition.
> > 
> > From: Jens.Osterkamp@de.ibm.com
> > Cc: netdev@vger.kernel.org
> 
> This one should be sent to Jeff Garzik, along with patches 11, 13 and
> 14.

Ok.

Jens, is it ok for you if you send the network driver stuff to
jgarzik@pobox.com, Cc: netdev@vger.kernel.org yourself in the future?

	Arnd <><
