From: kuznet@ms2.inr.ac.ru
Subject: Re: [RFC] SNMP_ADD_STATS
Date: Thu, 13 Jun 2002 02:47:46 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200206122247.CAA16949@sex.inr.ac.ru>
References: <20020612182348.GP1073@conectiva.com.br>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: acme@conectiva.COM.BR (Arnaldo Carvalho de Melo)
In-Reply-To: <20020612182348.GP1073@conectiva.com.br> from "Arnaldo Carvalho de Melo" at Jun 12, 2 10:45:00 pm
List-Id: netdev.vger.kernel.org

Hello!

> Any objections?

No objections, of course. In any case, access to per-cpu stats is to be
macroized to work with preemption.

Alexey
