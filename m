From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont" <remi-AzDNUFsAnHasTnJN9+BGXg@public.gmane.org>
Subject: Re: [PATCH net-next 0/6] Phonet: small pipe protocol fixes
Date: Sat, 26 Feb 2011 11:15:45 +0200
Message-ID: <201102261115.46319.remi@remlab.net>
References: <201102251113.41620.remi.denis-courmont@nokia.com>
	<20110225.112055.260096987.davem@davemloft.net>
	<20110225.112406.246526410.davem@davemloft.net>
Reply-To: remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org, ofono-bdc2hr5oBkPYtjvyW6yDsg@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ofono-bdc2hr5oBkPYtjvyW6yDsg@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <ofono-bounces-bdc2hr5oBkPYtjvyW6yDsg@public.gmane.org>
In-Reply-To: <20110225.112406.246526410.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <http://lists.ofono.org/options/ofono>,
	<mailto:ofono-request-bdc2hr5oBkPYtjvyW6yDsg@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ofono.org/pipermail/ofono>
List-Post: <mailto:ofono-bdc2hr5oBkPYtjvyW6yDsg@public.gmane.org>
List-Help: <mailto:ofono-request-bdc2hr5oBkPYtjvyW6yDsg@public.gmane.org?subject=help>
List-Subscribe: <http://lists.ofono.org/listinfo/ofono>,
	<mailto:ofono-request-bdc2hr5oBkPYtjvyW6yDsg@public.gmane.org?subject=subscribe>
Sender: ofono-bounces-bdc2hr5oBkPYtjvyW6yDsg@public.gmane.org
Errors-To: ofono-bounces-bdc2hr5oBkPYtjvyW6yDsg@public.gmane.org
List-Id: netdev.vger.kernel.org

Le vendredi 25 f=E9vrier 2011 21:24:06 David Miller, vous avez =E9crit :
> > From: "R=E9mi Denis-Courmont" <remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
> > Date: Fri, 25 Feb 2011 11:13:41 +0200
> > =

> >> This patch series cleans up and fixes a number of small bits in the
> >> Phonet pipe code, especially the experimental pipe controller. Once
> >> this small bits are sorted out, I will try to fix the controller
> >> protocol implementation proper so that we do not need the
> >> compile-time (experimental) flag anymore.
> > =

> > All applied thanks.
> > =

> > If you want to start using GIT to push phonet changes to me, frankly I
> > would welcome that :-)

No problem in principles. I need to figure out where to put linux-phonet.gi=
t =

though.

> BTW, I had to add the following patch to fix a build warning:

Hmm, right. I am planning to kill this config option and reunify the cough =

cough chal-len-ged *ahem* ST-Ericsson code with the Nokia code... So I conf=
ess =

did not bother to eliminate that ST-Ericsson-only mode warning.

-- =

R=E9mi Denis-Courmont
http://www.remlab.info/
http://fi.linkedin.com/in/remidenis
